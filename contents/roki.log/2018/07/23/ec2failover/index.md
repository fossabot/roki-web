---
title: VRRP on AWS VPC-EC2
date: 2018-07-23 06:05:00
tags: golang, AWS, Networking
header-warn: この記事は, <a href="https://falgon.github.io/roki.log/">旧ブログ</a>から移植された記事です. よって, その内容として, <a href="https://falgon.github.io/roki.log/">旧ブログ</a>に依存した文脈が含まれている可能性があります. 予めご了承下さい.
---

本エントリでは, VPC-EC2 で MASTER 側のヘルスが確認できなくなったときに, VRRP を用いてフェールオーバし, 
一定度の可用性担保を実現する場合について[^1]取り上げる. VRRP の実装としては keepalived を用いることとする.

## 前提

次のシチュエーションを前提としている.

* インスタンスが 2 つ以上作成済みで, 24, 80 番ポートを SG の設定で開けてあり, どちらにおいても apache2 と keepalived が稼働している.
* keepalived.conf にそれぞれ MASTER と BACKUP が設定済みで, VPC-EC2 のルートテーブルにて, いまの設定にあわせて 1 つに VIP (192.168.1.1/32) が設定してある.

このシチュエーションがオンプレミス環境上の話であれば, 何の問題もなく, これでフェールオーバが実現できるのだが,
AWS EC2 でこれを実現するためには, AWS のルートテーブル側の VIP ターゲットをも貼り直す操作が必要となり,
この操作については, ある程度自分で実装しなければならない. 
いくらか調べて見ると, awscli で同様の環境を作っている事例を多く見るのだが, 
本エントリでは諸事情より AWS SDK for go を使って, 操作することとした.

<!--more-->

## 設定と実装

結論からいえば, keepalived はユニキャストに対応しているので, それらの設定を行い, 互いに監視して,
MASTER または BACKUP となったときに自動でルートテーブルを操作すれば良い. 
もう少し細かく言えば, 冗長構成のうち監視対象となるインスタンスのプライベート IP を設定すれば良い.

そのついでに, VIP が設定されていることを簡単に取得できるように, VIP が設定されたインスタンスにタグを設定するようにしたい.
さらに, 毎度 keepalived.conf を作成するのは手間を要するので, 
冗長構成の中から監視対象や VIP などを自動検出して, keepalived.conf を生成するようにもしたい.

ということで, これらの要件を自動化するべく実装した.

<div class="box has-text-centered is-shadowless">
<i class="fab fa-github mr-2"></i>
<a href="https://github.com/falgon/VKUVC">VKUVC - VPC-EC2 + Keepalived Utilities = VRRP on Cloud</a>
</div>

動いている様子のデモビデオを録画した.

<div class="box has-text-centered is-shadowless">
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/b6y3CnaTiG0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

## 余談

今回 keepalived.conf の生成のために, はじめて`text/template`パッケージを用いた.
といっても簡単な使い方しかしていないので, 今回のような事例の他にも, まだまだ応用範囲は広そうだが, それにしても中々便利であった.
また今回で golang を使ってなにかモノを作ったのは [2 回目](/roki.log/2018/07/8/awsec2tag/)であるが,
段々と慣れてきたような気もする. 
とくに, AWS SDK に関しては, まあ元々使いやすいのは十分にあるのだが, 以前よりも大分勝手がわかってきた気がする.

[^1]: 普通にロードバランサもあるので, 選択肢としてこれに限るというわけではない.

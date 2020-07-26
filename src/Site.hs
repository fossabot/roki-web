{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Data.Foldable (fold)
import Hakyll
import Hakyll.Web.Sass

import Config
import qualified Config.RokiLog as CRL
import Contexts (postCtx, siteCtx)
import Media
import Utils (absolutizeUrls)
import qualified FontAwesome as FA

mediaRules :: Rules ()
mediaRules = do
    match "contents/images/**/*.svg" $ do
        route $ gsubRoute "contents/" $ const ""
        compile $ optimizeSVGCompiler ["-p", "4"]

    match "contents/images/**" $ do
        route $ gsubRoute "contents/" $ const ""
        compile copyFileCompiler
    
vendorRules :: Rules ()
vendorRules = do
    match "node_modules/@fortawesome/fontawesome-svg-core/styles.css" $ do
        route $ constRoute "vendor/fontawesome/style.css"
        compile compressCssCompiler

    match "node_modules/bulma/css/bulma.min.css" $ do
        route $ constRoute "vendor/bulma/bulma.min.css"
        compile compressCssCompiler

    match "node_modules/@creativebulma/bulma-tooltip/dist/bulma-tooltip.min.css" $ do
        route $ constRoute "vendor/bulma/bulma-tooltip.min.css"
        compile compressCssCompiler
    
styleRules :: Rules ()
styleRules = do
    match "contents/css/*" $ do
        route $ gsubRoute "contents/css/" $ const "style/"
        compile compressCssCompiler

    scssDepend <- makePatternDependency "contents/scss/*/**.scss"
    match "contents/scss/*/**.scss" $ compile getResourceBody
    rulesExtraDependencies [scssDepend] $
        match "contents/scss/*.scss" $ do
            route $ gsubRoute "contents/scss/" $ const "style/"
            compile $ fmap compressCss <$> sassCompiler

indexPageRule :: FA.FontAwesomeIcons -> Rules ()
indexPageRule faIcons = do
    match "contents/pages/index.html" $ do
        route $ gsubRoute "contents/pages/" (const "")
        compile $ do
            posts <- recentFirst =<< loadAllSnapshots CRL.entryPattern "content"
            let indexCtx = listField "posts" postCtx (return posts)
                    <> defaultContext
                    <> siteCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "contents/templates/default.html" indexCtx
                >>= relativizeUrls
                >>= FA.render faIcons

rokiLogRule :: FA.FontAwesomeIcons -> Rules ()
rokiLogRule faIcons = do
    -- each posts
    match CRL.entryPattern $ do
        route $ gsubRoute "contents/" (const "") `composeRoutes` setExtension "html"
        compile $ pandocCompilerWith readerOptions defaultHakyllWriterOptions
            >>= absolutizeUrls
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "contents/templates/post.html" postCtx
            >>= loadAndApplyTemplate "contents/templates/roki.log/default.html" postCtx
            >>= FA.render faIcons
            >>= relativizeUrls 

    match CRL.entryFilesPattern $ do
        route $ gsubRoute "contents/" (const "")
        compile copyFileCompiler

    -- the index page of roki.log 
    create ["roki.log/index.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAllSnapshots CRL.entryPattern "content"
            let blogCtx = listField "posts" postCtx (return posts)
                    <> constField "title" "Archives"
                    <> defaultContext
                    <> siteCtx

            makeItem ""
                >>= loadAndApplyTemplate "contents/templates/blog.html" blogCtx
                >>= loadAndApplyTemplate "contents/templates/roki.log/default.html" blogCtx
                >>= FA.render faIcons
                >>= relativizeUrls

main :: IO ()
main = hakyllWith hakyllConfig $ do
    faIcons <- fold <$> preprocess FA.loadFontAwesome

    mediaRules >> vendorRules >> styleRules

    match (fromList ["contents/pages/about.rst", "contents/pages/contact.markdown"]) $ do
        route $ gsubRoute "contents/pages/" (const "") `composeRoutes` setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "contents/templates/default.html" postCtx
            >>= relativizeUrls
    
    rokiLogRule faIcons
    indexPageRule faIcons
    
    match "contents/templates/**" $ compile templateBodyCompiler


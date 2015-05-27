# What?

Here is proposed skeleton for new `Yesod` project.

# What is wrong with current skeleton

## Foundation has no access to site internals

`Foundation` contains instance `Yesod App` with method `isAuthorized`
and other methods which often requires access to site internals.

## All Haskell code in project root

Code should be placed in `src` or `lib` directory.

# The proposal

## Other project structure

```haskell
App.FoundationImport  -- should be imported by `*.Handler` modules only
App.NoFoundationImport -- should be imported by any other module which must not be dependent from `App`
App.DB.* -- for models and working with database
App.Route.Home.Handler -- same as `Handler.Home` in old structure. This module depends on `Foundation` and have access to `Route App` (import App.FoundationImport)
App.Route.Home.Form -- for form types which is used in `App.Route.Home.Handler`. This module written in independent from `App` fassion (import App.NoFoundationImport)
App.Route.Home.Common -- some other code used in elsewhere in Form or Handler (import App.NoFoundationImport)
App.Common.* -- Some other common modules used anywhere in project. Should not depend on `App` and `import App.NoFoundation`
App.Handler -- Just reexports all handlers from `App.Route.{route path}.Handler` modules
```

Here is picture of module dependencies:

![Modules graph](https://rawgithub.com/s9gf4ult/yesod-skel/master/modules.svg)

## Minimize code in Handler

While all logic is moved to `Helper` namespace handlers become
minimalistic. This is a consequence of preceeding paragraph.

## Move all project code to `src`

No comments.

## Beautify cabal file

Add separating coma to module lists, sort module lists, sort
dependency lists, sort extensions list, normalize indenting, remove
blank spaces.

# What?

Here is proposed skeleton for new `Yesod` project.

# What is wrong with current skeleton

## Foundation has no access to site internals

`Foundation` contains instance `Yesod App` with method `isAuthorized`
and other methods which often requires access to site internals.

## All Haskell code in project root

Code should be placed in `src` or `lib` directory.

# The proposal

## Add Helper namespace

`Helper` namespace is for all logic which does not relate with page
rendering and/or redirecting. Like working with DB, authentication,
authorization, form parsing.

All this gives an ability to reduce `Handler` modules as much as we
can.

This project already contains example of what is proposed. Here is
module `Handler.Import`

```haskell
module Handler.Import
    ( module Import
    ) where

import ClassyPrelude.Yesod   as Import

import Foundation            as Import
import Settings              as Import
import Settings.StaticFiles  as Import
import Yesod.Core.Types      as Import (loggerSet)
import Yesod.Default.Config2 as Import
```

which is imported by all handlers. And here is module `Helper.Import`
which is imported by `Helper` namespaced modules.

```haskell
module Helper.Import
       ( module Import
       , HasSettings(..)
       , Handler
       , Form
       ) where

import ClassyPrelude.Yesod   as Import

import Settings              as Import
import Settings.StaticFiles  as Import
import Yesod.Core.Types      as Import (loggerSet)
import Yesod.Default.Config2 as Import

class HasSettings a where
    getSettings :: a -> AppSettings

type Handler m =
    ( MonadHandler m
    , HasSettings (HandlerSite m)
    )

-- | A convenient synonym for creating forms.
type Form app x =
    (RenderMessage app FormMessage)
    => Html -> MForm (HandlerT app IO) (FormResult x, WidgetT app IO ())
```

As you can see type `Form` is now moved from `Foundation` to this
file. There is also an example of how to get access to `AppSettings`
from `Helper` modules: typeclass `HasSettings` which instance is
implemented in `Foundation`:

```haskell
instance HasSettings App where
    getSettings = appSettings
```

So, all code in namespace `Helper` is unbound from `App` and so can be
accessed from `Foundation`. It is poposed to add typeclasses in
`Helper.Import` to get access to properties of `App` from `Helper`, so
the logic in `Helper` modules will be authomatically portable and can
be moved to subsite or even different package.

Constraint `type Handler` can be used as replacement of `type Handler`
from `Founation` in usual handlers:

```haskell
module Helper.Authentication where

import Helper.Import

-- | Authenticate user or redirect to login page
authenticateUser :: (Handler m) => m UserId
authenticateUser = ...
```

instead of

```haskell
-- | Authenticate user or redirect to login page
authenticateUser :: Handler UserId
authenticateUser = ...
```

like in usual handlers.

Form parsing is also proposed to implement in `Helper`. Here is an
example of how we can write `App`-indenedent forms:

```haskell
module Helper.Home where

import Helper.Import

import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3,
                              withSmallInput)


sampleForm :: Form app (FileInfo, Text)
sampleForm = renderBootstrap3 BootstrapBasicForm $ (,)
    <$> fileAFormReq "Choose a file"
    <*> areq textField (withSmallInput "What's on the file?") Nothing
```

### Pros

* All site logic is unbound from `App` so it is portable from the
  begining. It can be moved to subsite and/or different package.

* `Foundation` has access to internal site logic like authentication
  and authorization which is required by `Yesod App` and `YesodAuth
  App` instances (and maybe something else).

* Handlers are minimalistic, they are simple to modify and
  understand. They contain just logic of page rendering and
  redirecting.

### Cons

* `Helper` have no direct access to `App`

* `Helper` have no direct access to `Route App` which can be a
  problem.

* Project structure becomes more complex.

## Minimize code in Handler

While all logic is moved to `Helper` namespace handlers become
minimalistic. This is a consequence of preceeding paragraph.

## Move all project code to `src`

No comments.

## Beautify cabal file

Add separating coma to module lists, sort module lists, sort
dependency lists, sort extensions list, normalize indenting, remove
blank spaces.

# RealmIO

`RealmIO` makes `Realm` type-safely and composable by using `reader monad`.

## Usage

`RealmIO<RW, T>` represents a realm action.

+ `RW` is actually `Read` or `Write`. It represents that action is readonly or not.
+ `T` is a return value type.

For example, action that reads `User` object from realm will be typed `RealmIO<Read, User>`.

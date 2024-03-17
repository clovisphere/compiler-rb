# A compiler (written in Ruby).

> It should probably be called a "transpiler" 🤭

```console
comnpiler.rb       # The compiler
example            # The toy language
README.md          # Well... Read it!!!
```

## Prerequisite

You need both a `ruby` and `node` interpreter for this to work 🙃

- [Ruby](https://www.ruby-lang.org/en/downloads/)
- [Node](https://nodejs.org/en)

## Run the code

```bash
ruby compiler.rb | node
# 3 -> what should you get/see :-)
```

Feel free to change the literal arguments to `f` on [Line #5](./compiler.rb?plain=1#L5).

Example:

```ruby
TEST = 'console.log(f(4, 22));'
```

This work is based on the excellent [A Compiler From Scratch](https://www.destroyallsoftware.com/screencasts/catalog/a-compiler-from-scratch) screencast from [Gary Bernhardt](https://www.destroyallsoftware.com/).

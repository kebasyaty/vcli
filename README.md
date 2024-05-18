# Vizbor CLI

**Helper console application for the <a href="https://github.com/kebasyaty/vizbor" alt="Vizbor">Vizbor</a> project.**

[![CI](https://github.com/kebasyaty/vcli/actions/workflows/specs.yml/badge.svg)](https://github.com/kebasyaty/vcli/actions/workflows/specs.yml")
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](LINK-TO-DOCUMENTATION)
[![Crystal](https://img.shields.io/badge/crystal-v1.12.1%2B-CC342D)](https://crystal-lang.org/)
[![GitHub release](https://img.shields.io/github/release/kebasyaty/vcli)](https://github.com/kebasyaty/vcli/releases/)
[![GitHub license](https://img.shields.io/github/license/kebasyaty/vcli)](https://github.com/kebasyaty/vcli/blob/main/LICENSE)
[![GitHub repository](https://img.shields.io/badge/--ecebeb?logo=github&logoColor=000000)](https://github.com/kebasyaty/vcli)

<p>
  <a href="https://github.com/kebasyaty/vcli" alt="Status Project">
    <img src="https://raw.githubusercontent.com/kebasyaty/vcli/main/pictures/status_project/Status_Project-Development-.svg"
      alt="Status Project">
  </a>
</p>

## Requirements

[View the list of requirements.](https://github.com/kebasyaty/vcli/blob/main/REQUIREMENTS.md "Requirements")

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   development_dependencies:
     vcli:
       github: kebasyaty/vcli
   ```

## Usage

```crystal
bin/vcli --help
```

Return:

```text
-v, --version                 Print version
-h, --help                    Show this help
-i, --init                    Initialize project
-a NAME, --add=NAME           Add a new service
-d NAME, --delete=NAME        Delete service
-r TOKEN, --restore=TOKEN     Restore access to admin panel
```

`token - username or email`

## Contributing

1. Fork it (<https://github.com/kebasyaty/vcli/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [kebasyaty](https://github.com/kebasyaty) Gennady Kostyunin - creator and maintainer

## Changelog

[View the change history.](https://github.com/kebasyaty/vcli/blob/main/CHANGELOG.md "View the change history.")

## License

**This project is licensed under the** [MIT](https://github.com/kebasyaty/vcli/blob/main/LICENSE "MIT")**.**

<br>
<br>
<div>
  <a href="https://crystal-lang.org/" alt="Made with Crystal">
    <img width="100%" src="https://raw.githubusercontent.com/kebasyaty/vcli/main/pictures/made-with-crystal.svg"
      alt="Made with Crystal">
  </a>
</div>

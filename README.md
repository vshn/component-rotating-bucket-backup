# Commodore Component: rotating-bucket-backup

This is a [Commodore][commodore] Component to manage S3 bucket backups.

The component creates a backup of an S3 bucket and stores it in another S3 bucket.
The component creates a new bucket for each day of the month and stores the backup in the corresponding bucket.
It then rotates by overwriting the corresponding bucket on the same day of the month.

This repository is part of Project Syn.
For documentation on Project Syn and this component, see [syn.tools](https://syn.tools).

## Documentation

The rendered documentation for this component is available on the [Commodore Components Hub](https://hub.syn.tools/rotating-bucket-backup).

Documentation for this component is written using [Asciidoc][asciidoc] and [Antora][antora].
It can be found in the [`docs`](docs) folder.
We use the [Divio documentation structure](https://documentation.divio.com/) to organize our documentation.

Run the `make docs-serve` command in the root of the project, and then browse to http://localhost:2020 to see a preview of the current state of the documentation.

After writing the documentation, please use the `make docs-vale` command and correct any warnings raised by the tool.

## Contributing and license

This library is licensed under [BSD-3-Clause](LICENSE).
For information about how to contribute, see [CONTRIBUTING](CONTRIBUTING.md).

[commodore]: https://syn.tools/commodore/
[asciidoc]: https://asciidoctor.org/
[antora]: https://antora.org/

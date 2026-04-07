# Lab-UnitTests

Support materials for a presentation on writing clean, maintainable unit tests in Laravel through interface-based architecture and dependency inversion.

## Overview

This repository currently contains a Marp presentation focused on:

- using interfaces to reduce coupling
- applying dependency injection in Laravel
- improving testability with mocks
- keeping unit tests fast, isolated, and maintainable

## Project Structure

```text
Lab-UnitTests/
|-- README.md
`-- Presentation/
    |-- README.md
    |-- build.ps1
    `-- images/
```

## Run the Presentation

From the `Presentation` folder:

```powershell
./build.ps1
```

This starts a local Marp server on `http://localhost:8080/` and opens the presentation in your browser.

## Requirements

- PowerShell
- Node.js
- `npx` available in your environment

The presentation is served with `@marp-team/marp-cli`.

## Main Files

- `Presentation/README.md`: slide deck source in Marp Markdown
- `Presentation/build.ps1`: helper script to launch the local presentation server
- `Presentation/images/`: presentation logos and assets

## Topic Covered

The presentation explains how to:

1. define contracts with interfaces
2. inject abstractions instead of concrete classes
3. bind implementations in Laravel's service container
4. test services with mocked dependencies

## Notes

Some content inside the presentation file appears to use inconsistent text encoding. The root README has been cleaned without changing the slide content itself.

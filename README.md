# BAFF (Bristol Aircraft File Format)
A matlab toolbox to create platform / analysis tool agnostic files defining aircraft geometries.

Items such as the fuselage / wings / engines can be defined programmatically and can be saved in a format that is independent of a particular analysis tool.

Currently BAFF geometries can only be generated in Matlab, however all BAFF aircraft can be saved to an hdf5 file, which *could* be read by any analysis tool on any platform.

## Analysis Tools using BAFF files

[ADS](https://github.com/DCRG-Bristol/ads) - A tool to generate Nastran models and run aeroelastic simulations

## Getting Started
- Either clone or download the repository
- add the folder tbx to the path or instal with the Matlab Pacakge Manager (mpm)
    - mpm install ads -u <INSTALL_DIR> --local -e --force
- have a look at the examples in the 'Examples' folder to get a flavour of what you can currently do.

### Prerequisites

This product was developed in MATLAB 9.12 (2022a)

## Running the tests
- To run the core set of tests type `runtests([path/to/folder/tests])`

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/farg-bristol/Matran/tags). 

## Authors
* **fh9g12**

See also the list of [contributors](https://github.com/DCRG-bristol/baff/contributors) who participated in this project.

## License

This project is licensed under the Apache License - see the [LICENSE.md](https://github.com/farg-bristol/Matran/blob/master/LICENSE) file for details

## Acknowledgments

* Inspired by the [pyNastran](https://github.com/SteveDoyle2/pyNastran) package by Steve Doyle.

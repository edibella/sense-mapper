# +SenseMapper

This is a package for housing tools that map out coil sensitivity profiles from multi-coil data. Right now it contains an object `MapEstimator` which can estimate coil sensitivity maps from multi-coil Cartesian image data.

## NPM

This package uses the node package manager to manage its version control and dependencies. To use this package simply:

1. Install Node: https://nodejs.org/en/

2. Run `npm install sense-mapper` at a unix-like terminal.

This will automatically download the files for this package (and the packages it depends on) into a `node_modules` folder. If you add this folder to your MATLAB path the `SenseMapper` package will be available.

It is crucial to note the difference in naming conventions between MATLAB and NPM. The npm package name is `sense-mapper` and the MATLAB package name is `+SenseMapper`. If you are new to MATLAB packages please learn more about them here: http://www.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html.


### Tests

To make sure this software works as expected in the present environment, tests have been provided and can be run by executing `SenseMapper.test`. These tests provide a very basic data-in data-out testing and it's these example data files that take up the bulk of the size of this repository.

Since all test data is stored in +tests/private, the files in this folder should not be version controlled. You need to tell your local `git` to not track changes in them via `git update-index --assume-unchanged` as described here: http://stackoverflow.com/questions/12288212/git-update-index-assume-unchanged-on-directory.

If you want to contribute to this project please keep tests in mind and do not commit any new data without telling git to "assume-unchanged" to avoid bloating the .git file.

### Docs

In the `docs/` directory some markdown files are provided explaining how to use each of the functions and classes this package provides.

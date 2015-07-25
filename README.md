SubmissionApp2
===

The second iteration of the original [SubmissionApp](https://github.com/bshlgrs/SubmissionApp). This application provides a system of accepting submissions from students. Designed for Haskell plaintext submissions or archive files, but can be extended to other types. Currently plaintext submission compilation and unit testing is implemented for Haskell, Ada and Chapel.

## Features

#### Statistics
Charts and statistics for assessment allows you to view class participation at a glance. Data is also available for individual class groups.

![Screenshot of data visualisation options](https://github.com/frankzhao/SubmissionApp2/raw/master/doc/charts.png)

#### Compilation
Automatic compilation of submissions allows for instant feedback and easier marking.

![Screenshot of compilation example](https://github.com/frankzhao/SubmissionApp2/raw/master/doc/compilation.png)

#### Syntax Highlighting
Built in syntax highlighting for plaintext submissions.

![Screenshot of syntax highlighting](https://github.com/frankzhao/SubmissionApp2/raw/master/doc/syntax-highlight.png)

#### File Export and Preview
Submissions can be exported to PDF files, or zip archives, both configurable with file blacklists. Ability to combine zip archives by groups is also included. Online previews of files contained in zip submissions is also possible.

### ...and more!
Additional features include full text search of submissions, group management, notifications, individial user profiles, user roles, assessment extensions, admin dashboard...

Setup
===

- `rake db:seed` will create admin user with uid 'u0000000' and password 'admin'
- Seeding will also create demo users `u0000001` (convenor), and `u0000002` (student) with the password `pass`
- Restart server using `./restart_server.sh`
- For development, the server can be restarted with `./restart_development.sh`
- If you have SSL certificates, place them in a folder named `ssl` inside the application root and edit the restart script to include the certificate and key filenames.

Dependencies
===

Dependencies marked in *italic* are currently using system installations on varese.

- Ruby 2.1.0p0 (built with OpenSSL support)
- *Rails 4.0.2*
- SQLite3 (sqlite3, libsqlite-dev)
- OpenSSL ( *openssl*, libopenssl-dev)
- *Latex (pdflatex, gs)*, requires url.sty. Additional templates can be installed in ~/texmf if using texlive-latex-base.
- *Haskell platform (ghc, runhaskell, ghci)*
- *GNAT 2015 (gnatmake)*
- Chapel 1.11.0

Manual Restart/Shutdown
===

Generally it is sufficient just to run the restart script.
To gracefully shut down the server, execute the following commands from the application root.

```
bundle exec thin stop
bin/delayed_job stop
```

To start the server manually, run the restart script. Errors involving non existent PIDs can be ignored.

Modules
===

SubmissionApp2 allows for the addition of language modules for compilation and unit testing. There are 3 modules currently implemented, for Haskell, Ada and Chapel. Tests for execution can be specified during assignment creation. Multiple tests can be specified with newline seperation.

##Haskell
The Haskell compilation module runs units tests using the GHC compiler. Tests can be using boolean expressions. Haskell syntax and function calls are permitted.

Example:
```
size_of_tree example_tree == 10
depth_of_tree example_tree == depth_of_tree reverse(example_tree)
```

##Ada
The Ada compilation module runs on GNAT 2015. Simple command line unit tests are supported to compare executing with specific command line arguments with `stdout`. The compare operator is `==`.

Example:
```
param == Hello World!
```

This will execute `./filename param` and check that the program output is equal to "Hello World!"

##Chapel
The Chapel compilation module runs on `chpl` v1.11.0. Like the Ada module, the compare operator is `==`, and will be passed as command line parameters.

Example:
```
--var=param == Hello World!
```

This will execute `./filename --var=param` and check that the program output is equal to "Hello World!"

## Custom
There is also a custom compilation module that allows specification of a custom compilation command. This is particularly powerful as it allows for solutions such as remote execution and hooks.

Notes
===

- The database is in the `db` folder
- Submissions are saved in `public/uploads`
- Additional libraries can be placed in `Library` to be included during Haskell submission compilation
- For backup purposes, the most important folders to back up is the database and the user uploads

SubmissionApp2
===

The second iteration of the original [SubmissionApp](https://github.com/bshlgrs/SubmissionApp). This application provides a system of accepting submissions from students. Designed for Haskell plaintext submissions or archive files, but can be extended to other types. Currently plaintext submission compilation and unit testing is only implemented for Haskell.

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
- sqlite3, libsqlite3-dev
- OpenSSL ( *openssl*, libopenssl-dev)
- *Latex (pdflatex, gs)*, requires url.sty. Additional templates can be installed in ~/texmf if using texlive-latex-base.
- Haskell platform (ghc, runhaskell, ghci).

Manual Restart/Shutdown
===

Generally it is sufficient just to run the restart script.
To gracefully shot down the server, execute the following commands from the application root.

bundle exec thin stop
bin/delayed_job stop

To start the server manually, run the restart script. Errors involving non existent PIDs can be ignored.
Notes
===

- Submissions are saved in `public/uploads`
- Additional libraries can be placed in `Library` to be included during submission compilation

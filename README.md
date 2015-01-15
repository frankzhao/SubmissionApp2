SubmissionApp2
===

The second iteration of the original [SubmissionApp](https://github.com/bshlgrs/SubmissionApp). This application provides a system of accepting submissions from students. Designed for Haskell plaintext submissions or archive files, but can be extended to other types. Currently plaintext submission compilation and unit testing is only implemented for Haskell.

Setup
===

- `rake db:seed` will create admin user with uid 'u0000000' and password 'admin'
- Seeding will also create demo users `u0000001` (convenor), and `u0000002` (student) with the password `pass`
- Restart server using `./restart_server.sh`
- For development, the server can be restarted with `./restart_development.sh`
- If you have SSL certificates, place tem in a folder named `ssl` and edit the restart script to include the certificate and key filenames.

Notes
===

- Submissions are saved in `public/uploads`
- Additional libraries can be placed in `Library` to be included during submission compilation

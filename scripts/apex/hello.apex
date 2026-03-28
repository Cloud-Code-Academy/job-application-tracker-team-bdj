// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
// Query events that already exist in the org
Event evt = new Event(
    Subject = 'Interview Too Long',
    StartDateTime = DateTime.newInstance(2025, 1, 6, 9, 0, 0),
    EndDateTime = DateTime.newInstance(2025, 1, 6, 10, 30, 0)
);
insert evt;
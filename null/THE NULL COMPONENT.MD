*The Null component*

Starting point for wrapping/converting legacy HawkEar code into components and/or writing new (hopefully not main-line) components in Octave.

Demonstrates:
1. How to initialise a component so that its APIs are accessible 
2. The two ways of invoking a HOS API from the commandline
3. Required format for parameters to HOS APIs
4. Obtaining the return code from an API
5. invoking HOS commands written in Octave from the Octave IDE
6. Split of parameter parsing from core functions

Implements an API called printp. The printp API accepts two positional parameter and several keyword parameters of the form -keyword:value. printp's is to display the parameters it receives. If supplied with the -h or -help parameters it displays how many positional parameters it expects and the keywords (with default values) it can accept.

The null component consists of:
1. myvars.cmd. Optional. Sets up environment variables to provide access to the resources the component needs. Called by hoscall.cmd
2. printp.cmd. A windows batch file that launches the printp command from a commandline
3. printp.m. An Octave command file (i.e. a function for which all parameters are strings). It:
   a. Receives the parameters in the format supplied from the Octave IDE commandline
   b. Receives the parameters in a munged format from printp.cmd and de-munge them
   c. Validates and type-convert the parameters
   d. Calls the doprintp() function
4. doprintp.m. An Octave function where the "work" is done. This command receives its parameters in the normal way for an Octave function. 



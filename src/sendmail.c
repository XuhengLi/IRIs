#include <stdio.h>
#include <string.h>


int sendmail(char* body, char* email){
        char cmd[100];  // to hold the command.
     // email id of the recepient.
         // email body.
        char tempFile[100];     // name of tempfile.

        //strcpy(tempFile,tempnam("/tmp","sendmail")); // generate temp file name.

        //FILE *fp = fopen(tempFile,"w"); // open it for writing.
        //fprintf(fp,"%s\n",body);        // write body to it.
        //fclose(fp);             // close it.

        
        strcat (str,"is your name?");
        sprintf(cmd," echo %s | mail -s \"noreply at `date`\" %s",body,email); // prepare command.
        system(cmd);     // execute it.

        return 0;
}
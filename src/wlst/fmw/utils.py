"""
Module with common functions used by the wlst scripts used by the infrastruture package
"""
import sys
import os

import java.io.File
import java.io.FileWriter
import java.io.IOException
import java.io.Writer
import java.lang.System as System


def getpassword(username):
    """
    Retrieves the password from the commom location.
    The password file is a properties file located in the scripts tmp dir
    If the file does'nt exist it creates a new one.

    :param username: a String containing the key that identifies
    the desired password
    :return: a String containing the found password (empty if none)
    """

    username = username.upper()
    password_file = os.getenv('SCRIPTS_TMP') + '/password.properties'
    passwords = {}
    a_file = None
    try:
        a_file = open(password_file, 'r+')
        file_lines = a_file.readlines()
        for line in file_lines:
            line = line.rstrip()  # removes trailing whitespace and '\n' chars
            if "=" not in line: continue  # skips blanks and comments w/o =
            if line.startswith("#"): continue  # skips comments which contain =

            k, v = line.split("=", 1)
            passwords[k] = v
    except IOError:
        a_file = open(password_file, 'w+')
        print 'Creating Password File at : ' + password_file

    try:
        apassword = passwords[username]
    except:
        # Prompt for Password
        console = System.console()
        input_passwd = console.readPassword("%s", [username + " PASSWORD: "])
        apassword = "".join(input_passwd)
        a_file.write(username + '=' + apassword + '\n')

    a_file.close()
    return apassword


def create_file(directoryname, filename, content):
    """
    Creates a file on the given path/content

    :param directoryname: A String containing the path where the file will be written
    :param filename: A String with the filename
    :param content: A string with the content
    """
    directory = java.io.File(directoryname);
    file = java.io.File(directoryname + '/' + filename);

    writer = None;
    try:
        directory.mkdirs();
        if not file.exists():
            file.createNewFile();
            writer = java.io.FileWriter(file);
            writer.write(content);

    finally:
        try:
            if writer is not None:
                writer.flush();
                writer.close();
        except java.io.IOException, e:
            e.printStackTrace();


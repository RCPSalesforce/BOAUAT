/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CadmusHttpResponse {
    global String adminKey {
        get;
        set;
    }
    global String adminUserName {
        get;
        set;
    }
    global Blob base64 {
        get;
        set;
    }
    global List<cadmus.CadmusHttpResponse.Issue> issues {
        get;
        set;
    }
    global String key {
        get;
        set;
    }
    global cadmus.MetadataWrapper metadata {
        get;
        set;
    }
    global String result {
        get;
        set;
    }
    global CadmusHttpResponse() {

    }
global class Issue {
    global String description {
        get;
        set;
    }
    global String level {
        get;
        set;
    }
    global Issue() {

    }
}
}

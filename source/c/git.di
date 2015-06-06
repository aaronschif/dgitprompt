extern (C):

struct CGitStatus{
    size_t ahead;
    size_t behind;
    int new_files;
    int working_files;
    int index_files;
    int stash;
    int state;
    const(char) *tag;
    const(char) *branch;
};

void find_status(CGitStatus*, immutable(char)*);

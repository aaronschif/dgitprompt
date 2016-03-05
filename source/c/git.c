#include <git2.h>

typedef struct GitStatus{
    size_t ahead;
    size_t behind;
    int new_files;
    int working_files;
    int index_files;
    int stash;
    int state;
    const char *tag;
    const char *branch;
    const char *hash;
} git_status;

void get_branch(git_repository *repo, git_status *status) {
    if (git_repository_is_empty(repo)) {
        status->branch = "";
        return;
    }

    git_reference *head = NULL;
    git_repository_head(&head, repo);
    if (git_reference_is_branch(head))
        status->branch = git_reference_shorthand(head);
    else
        status->branch = NULL;
}

void get_tag(git_repository *repo, git_status *status) {
    const git_oid *local_oid;
    git_reference *head;
    git_tag *tag;

    if (git_repository_head(&head, repo)) return;
    local_oid = git_reference_target(head);

    if (git_tag_lookup(&tag, repo, local_oid)) {
        status->tag = NULL;
        return;
    }
    status->tag = git_tag_name(tag);
    git_tag_free(tag);
}

void get_state(git_repository *repo, git_status *status) {
    status->state = git_repository_state(repo);
}

int _stash_cb(size_t index, const char *message, const git_oid *stash_id, void *payload) {
    (*((int*) payload)) ++;
    return 0;
}

void get_stash(git_repository *repo, git_status *status) {
    int payload = 0;
    git_stash_foreach(repo, _stash_cb, &payload);
    status->stash = payload;
}

void get_remote(git_repository *repo, git_status *status) {
    const git_oid *local_oid, *remote_oid;
    git_reference *head, *remote;

    if (git_repository_head(&head, repo)) return;
    if (git_branch_upstream(&remote, head)) return;
    local_oid = git_reference_target(head);
    remote_oid = git_reference_target(remote);

    git_graph_ahead_behind(&status->ahead, &status->behind, repo, local_oid, remote_oid);
}

void get_changes(git_repository *repo, git_status *status) {
      int i;
      git_status_options opts = GIT_STATUS_OPTIONS_INIT;
      opts.show  = GIT_STATUS_SHOW_INDEX_AND_WORKDIR;
      opts.flags = GIT_STATUS_OPT_INCLUDE_UNTRACKED |
        GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX |
        GIT_STATUS_OPT_SORT_CASE_SENSITIVELY;

      git_status_list *status_list;
      git_status_list_new(&status_list, repo, &opts);

      for (i = 0; i < git_status_list_entrycount(status_list); ++i) {
          const git_status_entry *s = git_status_byindex(status_list, i);
          if (s->status == GIT_STATUS_CURRENT)
              continue;
          if (s->status & (GIT_STATUS_INDEX_NEW | GIT_STATUS_INDEX_MODIFIED | GIT_STATUS_INDEX_DELETED | GIT_STATUS_INDEX_RENAMED | GIT_STATUS_INDEX_TYPECHANGE))
              status->index_files++;
          if (s->status & (GIT_STATUS_WT_MODIFIED | GIT_STATUS_WT_DELETED | GIT_STATUS_WT_TYPECHANGE | GIT_STATUS_WT_RENAMED))
              status->working_files++;
          if (s->status & (GIT_STATUS_WT_NEW))
              status->new_files++;
      }
}

void get_hash(git_repository *repo, git_status *status) {
    const git_oid *local_oid;
    git_reference *head;

    if (git_repository_head(&head, repo)) return;
    local_oid = git_reference_target(head);

    status->hash = git_oid_tostr_s(local_oid);
}

void find_status(git_status* status, char* path) {
    git_repository *repo = NULL;
    git_libgit2_init();
    git_repository_open(&repo, path);

    get_tag(repo, status);
    get_state(repo, status);
    get_branch(repo, status);
    get_stash(repo, status);
    get_remote(repo, status);
    get_changes(repo, status);
    get_hash(repo, status);

    git_repository_free(repo);
    git_libgit2_shutdown();
}

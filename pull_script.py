import os
import subprocess

BASE_DIR = r"C:\Users\Hwei\AppData\Roaming\ModrinthApp\profiles\Computer Craft\saves\Computer Craft World\computercraft\computer"

def run_git(path, args):
    return subprocess.run(
        ["git", "-C", path] + args,
        capture_output=True,
        text=True
    )

def is_git_repo(path):
    return os.path.isdir(os.path.join(path, ".git"))

def get_repo_dirs():
    repos = []
    for item in os.listdir(BASE_DIR):
        full_path = os.path.join(BASE_DIR, item)
        if os.path.isdir(full_path) and is_git_repo(full_path):
            repos.append(full_path)

    return sorted(
        repos,
        key=lambda p: int(os.path.basename(p)) if os.path.basename(p).isdigit() else os.path.basename(p)
    )

def get_current_branch(path):
    result = run_git(path, ["branch", "--show-current"])
    if result.returncode != 0:
        return None

    branch = result.stdout.strip()
    return branch or None

def get_repo_root_from_cwd():
    """
    Detect the git repo root based on the current working directory.
    Run this script from inside the computer repo you want to use as the source.
    """
    cwd = os.getcwd()

    result = subprocess.run(
        ["git", "-C", cwd, "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return None

    return result.stdout.strip()

def has_uncommitted_changes(path):
    result = run_git(path, ["status", "--porcelain"])
    if result.returncode != 0:
        return False

    return bool(result.stdout.strip())

def is_ahead_of_remote(path):
    result = run_git(path, ["status", "-sb"])
    if result.returncode != 0:
        return False

    return "ahead" in result.stdout

def fetch_origin(path):
    return run_git(path, ["fetch", "origin"])

def checkout_branch(path, branch):
    repo_name = os.path.basename(path)

    # Try switching to an existing local branch first
    result = run_git(path, ["checkout", branch])
    if result.returncode == 0:
        print(f"✅ [{repo_name}] checked out local branch '{branch}'")
        return True

    # If it does not exist locally, try creating a tracking branch from origin/branch
    result = run_git(path, ["checkout", "-b", branch, "--track", f"origin/{branch}"])
    if result.returncode == 0:
        print(f"✅ [{repo_name}] created tracking branch '{branch}'")
        return True

    print(f"❌ [{repo_name}] could not checkout branch '{branch}'")
    if result.stderr.strip():
        print(result.stderr.strip())
    return False

def pull_current_branch(path):
    repo_name = os.path.basename(path)

    result = run_git(path, ["pull", "--ff-only"])
    if result.returncode == 0:
        print(f"✅ [{repo_name}] pull success")
        if result.stdout.strip():
            print(result.stdout.strip())
        return True

    print(f"❌ [{repo_name}] pull failed")
    if result.stderr.strip():
        print(result.stderr.strip())
    return False

def main():
    repos = get_repo_dirs()
    if not repos:
        print("No git repos found.")
        return

    source_repo = get_repo_root_from_cwd()
    if not source_repo:
        print("❌ Could not detect a git repo from the current folder.")
        print("Open a terminal inside the computer repo you want to use as the source, then run the script.")
        return

    source_repo = os.path.normpath(source_repo)
    normalized_repos = [os.path.normpath(r) for r in repos]

    if source_repo not in normalized_repos:
        print("❌ The repo you launched from is not inside the ComputerCraft computer folder list.")
        print(f"Detected source repo: {source_repo}")
        return

    source_branch = get_current_branch(source_repo)
    if not source_branch:
        print("❌ Could not determine the current branch of the source repo.")
        return

    if has_uncommitted_changes(source_repo):
        print("❌ Source repo has uncommitted changes. Commit first.")
        return

    if is_ahead_of_remote(source_repo):
        print("⚠️ Source repo has commits not pushed to remote.")
        print("Run 'git push' before syncing.")
        return

    source_name = os.path.basename(source_repo)

    print(f"Using source computer: {source_name}")
    print(f"Target branch: {source_branch}")

    for repo in repos:
        repo_name = os.path.basename(repo)
        normalized_repo = os.path.normpath(repo)

        if normalized_repo == source_repo:
            print(f"\n📌 Skipping source computer {repo_name}")
            continue

        print(f"\n📦 Processing computer {repo_name}")

        if has_uncommitted_changes(repo):
            print(f"⚠️ [{repo_name}] skipped because it has uncommitted changes.")
            continue

        fetch_result = fetch_origin(repo)
        if fetch_result.returncode != 0:
            print(f"❌ [{repo_name}] fetch failed")
            if fetch_result.stderr.strip():
                print(fetch_result.stderr.strip())
            continue

        if not checkout_branch(repo, source_branch):
            continue

        pull_current_branch(repo)

if __name__ == "__main__":
    main()
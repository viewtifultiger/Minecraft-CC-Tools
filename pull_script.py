import os
import subprocess

BASE_DIR = r"C:\Users\Hwei\AppData\Roaming\ModrinthApp\profiles\Computer Craft\saves\Computer Craft World\computercraft\computer"

def is_git_repo(path):
	return os.path.isdir(os.path.join(path, ".git"))

def pull_repo(path):
	repo_name = os.path.basename(path)
	print(f"\n📦 Pulling in: {repo_name}")
	result = subprocess.run(["git", "-C", path, "pull", "--ff-only"], capture_output=True, text=True)

	if result.returncode == 0:
		print(f"✅ Success:\n{result.stdout}")
	else:
		print(f"❌ Error:\n{result.stderr}")

def main():
	for item in os.listdir(BASE_DIR):
		full_path = os.path.join(BASE_DIR, item)
		if os.path.isdir(full_path) and is_git_repo(full_path):
			pull_repo(full_path)

if __name__ == "__main__":
	main()
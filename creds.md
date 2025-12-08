### How to set up github credentials in a ubuntu machine?

git config --global user.name "github_username"
git config --global user.email "email_address@gmail.com"

ssh-keygen -t ed25519 -C "email_address@gmail.com"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub (copy the SSH Key to your github account)

git remote set-url origin git@github.com:github_username/bulk-rna-sequencing.git

ssh -T git@github.com


### How to set up github credentials in a ubuntu machine?

git config --global user.name "GenTech2025"
git config --global user.email "roysourav2023.uk@gmail.com"

ssh-keygen -t ed25519 -C "roysourav2023.uk@gmail.com"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub (copy the SSH Key to your github account)

git remote set-url origin git@github.com:GenTech2025/bulk-rna-sequencing.git

ssh -T git@github.com


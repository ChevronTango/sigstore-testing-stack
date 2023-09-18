# sigstore-testing-stack

```
brew tap sigstore/tap
brew install gitsign

git config --global commit.gpgsign true  # Sign all commits
git config --global tag.gpgsign true  # Sign all tags
git config --global gpg.x509.program gitsign  # Use Gitsign for signing
git config --global gpg.format x509  # Gitsign expects x509 args

git config --global gitsign.fulcio $(gp url 5555) # Private Fulcio
git config --global gitsign.rekor $(gp url 3000) # Private Rekor
git config --global gitsign.issuer $(gp url 5556) # Private Issuer

git commit -m "Test" --allow-empty
```
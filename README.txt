Written my Jake Bowles for Frog Kirkman.

1. I would advise adding a backend which requires a storage account/container
2. I would advise storing the passwords in a Key Vault. 
3. VPN connection (Dev & Prod) have had dummy IP values added for testing purposes.
4. I have commented out the section where the NSG is attached to the VM subnet because terraform plan doesn't run correctly due to dependencies linking the count variable. When an apply is ready (or after it has been done once), this can be uncommented.
5. There is no internet access to the Intranet. VPN traffic only
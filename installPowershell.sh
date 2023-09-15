#!/bin/bash

Installs powershell and a few modules

brew install --cask powershell && \
	echo 'Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force' | pwsh -f - && \
	echo 'Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force' | pwsh -f - 
	

#!/bin/sh

#  ci_post_clone.sh
#  SLT Usage Meter
#
#  Created by Prabhashwara on 2026-01-18.
#

# Navigate to the Shared directory relative to the repository root
# Adjust the path if your repository structure is different
cd "$CI_PRIMARY_REPOSITORY_PATH/Usage-Meter-for-SLT/Shared" || exit 1

# Create Secrets.swift using the CLIENT_ID environment variable
echo "Creating Secrets.swift..."
echo "import Foundation" > Secrets.swift
echo "" >> Secrets.swift
echo "struct Secrets {" >> Secrets.swift
echo "    static let clientId = \"$CLIENT_ID\"" >> Secrets.swift
echo "}" >> Secrets.swift

echo "Secrets.swift created successfully."

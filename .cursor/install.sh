#!/usr/bin/env bash
# Idempotent Cloud Agent setup for the SQA Inspection App.
# - Installs the official .NET SDK 8 (the Ubuntu-packaged SDK omits the
#   Microsoft.NET.Sdk.WindowsDesktop targets that the WinForms/FlaUI test
#   project needs to cross-build via EnableWindowsTargeting).
# - Restores and builds the FlaUI BDD test project (SpecFlow codegen + compile).
# Python 3 (stdlib only) already ships in the base image and powers both web
# dashboards, so no Python packages are installed here.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTNET_DIR="/usr/local/dotnet"

export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

if [ ! -x "${DOTNET_DIR}/dotnet" ]; then
  echo "[install] Installing official .NET SDK 8 into ${DOTNET_DIR}"
  curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
  chmod +x /tmp/dotnet-install.sh
  sudo mkdir -p "${DOTNET_DIR}"
  sudo /tmp/dotnet-install.sh --channel 8.0 --install-dir "${DOTNET_DIR}"
else
  echo "[install] .NET SDK already present at ${DOTNET_DIR}"
fi

# Expose dotnet on the default PATH for install, start, and terminals.
sudo ln -sf "${DOTNET_DIR}/dotnet" /usr/local/bin/dotnet

export DOTNET_ROOT="${DOTNET_DIR}"
export PATH="${DOTNET_DIR}:${PATH}"

echo "[install] dotnet version: $(dotnet --version)"

TEST_PROJECT="${REPO_ROOT}/Automation_testcase/Project_FlaUIBDD/Testcase_Inspection_App_FlaUI_BDD/Testcase_Inspection_App_FlaUI_BDD.csproj"
echo "[install] Restoring and building FlaUI BDD test project"
dotnet build -c Release "${TEST_PROJECT}"

echo "[install] Setup complete."

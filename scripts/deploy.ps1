# Author: Rajesh Ediga
# Deploys Salesforce ComponentHub to the default/target org.
param(
    [string]$TargetOrg = "componenthub"
)

sf project deploy start --source-dir force-app --target-org $TargetOrg
sf apex run test --class-names CH_ComponentHubTest,FileExtensionRestrictionServiceTest --result-format human --code-coverage --target-org $TargetOrg

- DONE Generate an ENR if one is not passed to it in a values file. Store it in a k8s secret.
- DONE It should log the ENR public key in the templated notes.txt that helm outputs. Telling the user to submit this ENR public key in the cluster acceptance flow on the Launchpad.
- DONE the dkg-sidecar should poll for cluster invites(https://api.obol.tech/docs#/Cluster%20Definition/DefinitionController_getClusterDefinitionWithOperator_v1) for the passed in operator address. If there are several cluster invites pick the most recent one by default and log the otrhers config_hash. This step is leveraging the API directly.
    - It should look through all definitions, and see if it can find one where its generated ENR has been signed by its passed in operator address. That indicates that the user has completed the LP flow and used this Pod's ENR public key in sign up.
    - It should wait for the cluster definition to be fully signed by all operators, and be ready for DKG.
    - It should call getObolClusterDefinition of charon SDK to get the cluster definition from the config_hash
    - It should call acceptClusterDefinition of obol-sdk to accept the cluster definition if not yet done
    - It should start a DKG process when the definition is ready but no cluster-clock file is present.
    - It should retry the definition process if it exits with non-zero
    - It should store the dkg artifacts in a PV
    - It should start up the charon runtime container
    - It should start up a validator client containter


General rules:
- Use @obolnetwork/obol-sdk to interact with the Launchpad API
- If the cluster definition and the cluster-clock file are present charon should start right away
- If the cluster definition is present but the cluster-clock file is not present, charon should start a DKG process

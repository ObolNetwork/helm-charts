const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

// --- Reference Data (Adapted from obol-api/test/data/v1.10.0.ts groupClusterDefinitionNonCompoundingV1X10) ---

const CREATOR_ADDRESS = "0x24799A3A451F3E99518F60F109D09885F370191a"; 
const CREATOR_CONFIG_SIG = "0xd4090fc4132ecf6cd56a37710f160acb51b8e4aa504315c3d6986ecd2abb69740c5a50ec9a7d71dbabb73de481b7daa1b971a584dae70cf4bfcb6b9f6dc04e351c";

const OPERATOR_A_ADDRESS = "0x3D1f0598943239806A251899016EAf4920d4726d"; 
const OPERATOR_A_ENR      = "enr:-Ku4QEXAMPLEOPERATORAENRFROMTHEMOCKAPISERVERPLEASEMODIFYPREVIOUSVALUE";
const OPERATOR_A_CONFIG_SIG = "0xconfigsigAplaceholder"; 
const OPERATOR_A_ENR_SIG    = "0xenrsigAplaceholder";    

const OPERATOR_B_ADDRESS = "0x8953a653d6f3bC8C32d797773C986aA00629752a"; 
const OPERATOR_B_ENR      = "enr:-HW4QAKHz3KMrMlSFBoUlWNUTIb7_ZfHesv2axtp8wembBFISVA8oUMEeLJFrrQhaftWof73TwaBJvSGWuQY-0h6aNWAgmlkgnY0iXNlY3AyNTZrMaECwse5ClGbpdyD6NIKvIQACZEpJf7ueY2dqwTgQrQkC9I";
const OPERATOR_B_CONFIG_SIG = "0xconfigsigBplaceholder"; 
const OPERATOR_B_ENR_SIG    = "0xenrsigBplaceholder";    

const OPERATOR_C_ADDRESS = "0x7Ac679DF4947B675C73493a77179d6fDa7F8C251"; 
const OPERATOR_C_ENR      = "enr:-HW4QIH7JGgINCHlrhJBTc9LMYsVSIH3Wj-NbXeFwWJBphviWbEK4Z17HlTTmHlKKPeTNwnY3sub4oJuveY4dhUWMgOAgmlkgnY0iXNlY3AyNTZrMaEDaC9-4JUFqpvm42dCHKjB2UdR5G_F4WGBu6B8_BrEdHw";
const OPERATOR_C_CONFIG_SIG = "0xconfigsigCplaceholder"; 
const OPERATOR_C_ENR_SIG    = "0xenrsigCplaceholder";    

const OPERATOR_D_ADDRESS = "0xA2399A6462C0bd17f6f99eB839972C1971780998"; 
const OPERATOR_D_ENR      = "enr:-HW4QEESZRcjsz_WYXH-i4GIlbs6QydDkfM5FYqoTxpKY4ctX2DbHGNL1R2c560wIyX2BvPQkRzFMao74d31KIeluBmAgmlkgnY0iXNlY3AyNTZrMaECjGDrMWJT1PnNizXTbUQI9kIi-1iMNCaaPmu2aRpP31A";
const OPERATOR_D_CONFIG_SIG = "0xconfigsigDplaceholder"; 
const OPERATOR_D_ENR_SIG    = "0xenrsigDplaceholder";    

const fullBaseDefinition = {
  name: "test-group-non-compounding",
  uuid: "BB338EAD-08C1-BEAD-D9C6-8568D844D7AE",
  version: "v1.10.0",
  timestamp: "2025-02-24T11:02:27+01:00",
  num_validators: 2,
  threshold: 3,
  dkg_algorithm: "default",
  fork_version: "0x01017000", 
  deposit_amounts: null,
  consensus_protocol: "",
  target_gas_limit: 36000000,
  compounding: false,
  config_hash: "0xc10f8bf3fb5054c6f3bfde8ce88fe8b29ba2e74fab01ae70033bfc14dc7c6552",
  creator: {
    address: CREATOR_ADDRESS, 
    config_signature: CREATOR_CONFIG_SIG,
  },
  operators: [
    { address: OPERATOR_A_ADDRESS, enr: OPERATOR_A_ENR, config_signature: "", enr_signature: "" },
    { address: OPERATOR_B_ADDRESS, enr: OPERATOR_B_ENR, config_signature: "", enr_signature: "" },
    { address: OPERATOR_C_ADDRESS, enr: OPERATOR_C_ENR, config_signature: "", enr_signature: "" },
    { address: OPERATOR_D_ADDRESS, enr: OPERATOR_D_ENR, config_signature: "", enr_signature: "" },
  ],
  validators: [
    { fee_recipient_address: "0x0D941218c10b055f0907FE1BbE486ccdAa7e332A", withdrawal_address: "0x0D941218c10b055f0907FE1BbE486ccdAa7e332A" },
    { fee_recipient_address: "0x0D941218c10b055f0907FE1BbE486ccdAa7e332A", withdrawal_address: "0x0D941218c10b055f0907FE1BbE486ccdAa7e332A" },
  ],
  definition_hash: "0xac37a1e1ab6df855060495c82d0b882315b9275b9ef76987a7834372101f8b00",
  is_synced_to_all_participants: false 
};

app.get('/v1/definition/operator/:operatorAddress', (req, res) => {
  const requestedOperatorAddress = req.params.operatorAddress;
  const mockState = process.env.MOCK_DKG_STATE || "FRESH";

  console.log(`Mock API: Request for operator: ${requestedOperatorAddress}, MOCK_DKG_STATE: ${mockState}`);

  if (requestedOperatorAddress.toLowerCase() !== OPERATOR_A_ADDRESS.toLowerCase()) {
    console.log(`Mock API: Operator address ${requestedOperatorAddress} does not match primary test operator ${OPERATOR_A_ADDRESS}. Returning empty array.`);
    return res.json({ cluster_definitions: [], next_page: null });
  }

  let responseDefinitionObject;
  let responsePayload;

  switch (mockState.toUpperCase()) {
    case "FRESH":
      responsePayload = [];
      break;

    case "INVITED_SELF_SIGNED":
      responseDefinitionObject = JSON.parse(JSON.stringify(fullBaseDefinition));
      responseDefinitionObject.operators[0].config_signature = OPERATOR_A_CONFIG_SIG;
      responseDefinitionObject.operators[0].enr_signature = OPERATOR_A_ENR_SIG;
      responseDefinitionObject.is_synced_to_all_participants = false;
      responsePayload = [responseDefinitionObject];
      break;

    case "PARTIALLY_SIGNED": 
      responseDefinitionObject = JSON.parse(JSON.stringify(fullBaseDefinition));
      responseDefinitionObject.operators[0].config_signature = OPERATOR_A_CONFIG_SIG;
      responseDefinitionObject.operators[0].enr_signature = OPERATOR_A_ENR_SIG;
      responseDefinitionObject.operators[1].config_signature = OPERATOR_B_CONFIG_SIG;
      responseDefinitionObject.operators[1].enr_signature = OPERATOR_B_ENR_SIG;
      responseDefinitionObject.is_synced_to_all_participants = false;
      responsePayload = [responseDefinitionObject];
      break;

    case "FULLY_SIGNED": 
      responseDefinitionObject = JSON.parse(JSON.stringify(fullBaseDefinition));
      responseDefinitionObject.operators[0].config_signature = OPERATOR_A_CONFIG_SIG;
      responseDefinitionObject.operators[0].enr_signature = OPERATOR_A_ENR_SIG;
      responseDefinitionObject.operators[1].config_signature = OPERATOR_B_CONFIG_SIG;
      responseDefinitionObject.operators[1].enr_signature = OPERATOR_B_ENR_SIG;
      responseDefinitionObject.operators[2].config_signature = OPERATOR_C_CONFIG_SIG;
      responseDefinitionObject.operators[2].enr_signature = OPERATOR_C_ENR_SIG;
      responseDefinitionObject.operators[3].config_signature = OPERATOR_D_CONFIG_SIG; 
      responseDefinitionObject.operators[3].enr_signature = OPERATOR_D_ENR_SIG;
      responseDefinitionObject.is_synced_to_all_participants = true;
      responseDefinitionObject.definition_hash = fullBaseDefinition.definition_hash;
      responsePayload = [responseDefinitionObject];
      break;

    default:
      console.log(`Mock API: Unknown MOCK_DKG_STATE: ${mockState}. Returning FRESH state (empty array).`);
      responsePayload = [];
      break;
  }
  return res.json({ cluster_definitions: responsePayload, next_page: null });
});

app.listen(port, () => {
  console.log(`DKG Mock API server listening at http://localhost:${port}`);
  console.log(`To change state, set MOCK_DKG_STATE environment variable.`);
  console.log(`Current MOCK_DKG_STATE: ${process.env.MOCK_DKG_STATE || "FRESH (default)"}`);
  console.log(`Sidecar should poll for operator address: ${OPERATOR_A_ADDRESS}`);
});

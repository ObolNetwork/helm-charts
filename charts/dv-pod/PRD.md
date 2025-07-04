# Distributed Validator Chart - Product Requirements Document (PRD)

## 1. Overview
This document outlines the requirements for implementing a Helm chart that manages the full lifecycle of Distributed Validator (DV) pods in the Obol Network. The chart will handle the deployment and orchestration of Charon and Validator Client (VC) combinations.

## 2. Problem Statement
Currently, there's no streamlined way to manage the complete lifecycle of Distributed Validator pods in a Kubernetes environment. The process involves multiple manual steps for ENR generation, cluster definition signing, DKG process initiation, and validator client deployment.

## 3. Goals
- Create a Helm chart that manages the full lifecycle of DV pods (Charon + VC)
- Automate the process from cluster definition to active validation
- Ensure high availability and reliability of the validator nodes
- Provide clear feedback and status updates during the deployment process

## 4. Scope

### In Scope
- ENR generation and management
- Polling for cluster invites using operator address
- DKG process orchestration
- Charon runtime container deployment
- Validator client container deployment
- Persistent storage for DKG artifacts
- Health checks and monitoring

### Out of Scope (for MVP)
- Operator (cold key) phase handling
- Validation of execution layer side of cluster invites
- Fee recipient validation

## 5. User Stories

### As a Node Operator, I want to:
1. Deploy a DV pod by providing just my operator address
2. See the ENR public key in the Helm output to complete the Launchpad flow
3. Have the system automatically detect when my cluster definition is ready
4. Have the DKG process start automatically when all operators have signed
5. Have my validator client start automatically after successful DKG

## 6. Technical Requirements

### 6.1 Chart Components
1. **ENR Generator Job**
   - Generates an ENR if one is not provided
   - Stores ENR in a Kubernetes secret
   - Outputs ENR public key in Helm notes

2. **DKG Sidecar Container**
   - Polls for cluster invites using operator address
   - Validates cluster definitions
   - Initiates DKG process when ready
   - Handles retries and backoff

3. **Charon Container**
   - Runs the Charon middleware
   - Mounts DKG artifacts
   - Connects to beacon node endpoints

4. **Validator Client Container**
   - Runs the validator client software
   - Integrates with Charon

5. **Configuration**
   - Operator Ethereum address (required)
   - API endpoint for cluster definition
   - Retry and backoff configuration
   - Resource limits and requests

### 6.2 Data Flow
1. User installs chart with operator address
2. Chart generates ENR (if not provided)
3. User submits ENR public key via Launchpad
4. DKG sidecar polls for signed cluster definition
5. When definition is fully signed, DKG process starts
6. After successful DKG, Charon and VC containers start

## 7. API Integration

The chart will integrate with the Obol API to:
- Fetch cluster definitions
- Check operator signatures
- Validate cluster readiness

### API Endpoints
- `GET /v1/definition/operator/{operatorAddress}` - Check for cluster definitions

## 8. Configuration

### Required Values
```yaml
charon:
  operatorAddress: "0x..."  # Ethereum address of the operator
  dkgSidecar:
    enabled: true
    apiEndpoint: "https://api.obol.tech"  # Obol API endpoint
    initialRetryDelaySeconds: 5
    maxRetryDelaySeconds: 300
    retryDelayFactor: 1.5
    pageLimit: 10
```

### Optional Values
```yaml
charon:
  image:
    repository: obolnetwork/charon
    tag: v1.4.2
    pullPolicy: IfNotPresent
  resources:
    requests:
      cpu: "100m"
      memory: "256Mi"
    limits:
      cpu: "1000m"
      memory: "1Gi"

validatorClient:
  enabled: true
  image:
    repository: sigp/lighthouse
    tag: v4.0.1
  resources:
    requests:
      cpu: "100m"
      memory: "512Mi"
    limits:
      cpu: "1000m"
      memory: "2Gi"
```

## 9. Security Considerations

1. **Secrets Management**
   - ENR and private keys stored in Kubernetes Secrets
   - Appropriate RBAC to restrict access

2. **Network Security**
   - Pod-to-pod communication secured with network policies
   - API authentication for Obol API calls

3. **Resource Isolation**
   - Resource limits to prevent resource exhaustion
   - Pod anti-affinity for high availability

## 10. Monitoring and Observability

1. **Metrics**
   - Charon metrics endpoint
   - Validator client metrics
   - DKG process status

2. **Logging**
   - Structured logging for all components
   - Log aggregation

3. **Health Checks**
   - Liveness and readiness probes
   - Startup probes

## 11. Testing Strategy

1. **Unit Tests**
   - Template rendering
   - Configuration validation

2. **Integration Tests**
   - DKG process with mock API
   - Failure scenarios

3. **E2E Tests**
   - Full deployment lifecycle
   - Cluster formation

## 12. Deployment

### Prerequisites
- Kubernetes cluster
- Helm 3.x
- Sufficient resources for validators

### Installation
```bash
helm repo add obol https://obolnetwork.github.io/helm-charts
helm install my-validator obol/charon-cluster \
  --set charon.operatorAddress=0x1234...
```

## 13. Rollback Plan

1. Document rollback procedure
2. Test rollback in staging
3. Monitor deployment closely

## 14. Future Enhancements

1. Support for multiple validator clients
2. Automated updates and upgrades
3. Enhanced monitoring and alerting
4. Support for additional DKG algorithms

## 15. References

1. [Obol Network Documentation](https://docs.obol.tech)
2. [Charon GitHub Repository](https://github.com/ObolNetwork/charon)
3. [Helm Documentation](https://helm.sh/docs/)

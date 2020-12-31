# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ase-assignment
  labels:
    app: ase-assignment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ase-assignment
  template:
    metadata:
      labels:
        app: ase-assignment
    spec:
      containers:
      - name: ase-assignment
        image: gcr.io/GOOGLE_CLOUD_PROJECT/ase-assignment:COMMIT_SHA
        ports:
        - containerPort: 80
        # [START proxy_container]
      - name: cloudsql-proxy
        image: gcr.io/cloudsql-docker/gce-proxy:1.11
        command: ["/cloud_sql_proxy",
                  "-instances=api-project-114665101623:us-central1:ase-assignment-db=tcp:3306",
                  "-credential_file=/secrets/cloudsql/key.json"]
        # [START cloudsql_security_context]
        securityContext:
          runAsUser: 2  # non-root user
          allowPrivilegeEscalation: false
        # [END cloudsql_security_context]
        volumeMounts:
          - name: cloudsql-instance-credentials
            mountPath: /secrets/cloudsql
            readOnly: true
      # [END proxy_container]
    # [START volumes]
    volumes:
      - name: cloudsql-instance-credentials
        secret:
          secretName: google-credentials
    # [END volumes]
---
kind: Service
apiVersion: v1
metadata:
  name: ase-assignment
spec:
  selector:
    app: ase-assignment
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer

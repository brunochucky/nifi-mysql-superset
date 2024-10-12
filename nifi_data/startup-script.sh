#!/bin/bash

# Wait for NiFi to fully start
wait_for_nifi() {
    echo "Waiting for NiFi to be ready..."

    # Loop until NiFi is reachable on port 8080
    while ! curl -s http://localhost:8080/nifi-api/flow/about > /dev/null; do
        echo "NiFi is not yet available. Retrying in 10 seconds..."
        sleep 60
    done

    echo "NiFi is ready!"
}

# Wait for NiFi to fully start
wait_for_nifi

# Upload the template
echo "Uploading NiFi template..."
curl -v -F "template=@/opt/nifi/nifi-current/data/generate_table_json.xml" \
    -X POST http://localhost:8080/nifi-api/process-groups/root/templates/upload

# Get the template ID
template_list=$(curl -s http://localhost:8080/nifi-api/flow/templates)
template_id=$(echo $template_list | jq -r '.templates[0].id')

if [ -z "$template_id" ]; then
    echo "Template upload failed or template not found"
    exit 1
fi

# Get the process group ID (usually 'root' is the root process group ID)
process_group_id=$(curl -s http://localhost:8080/nifi-api/process-groups/root | jq -r '.id')

# Instantiate the template on the canvas
echo "Instantiating template on canvas..."
curl -X POST http://localhost:8080/nifi-api/process-groups/$process_group_id/template-instance \
    -H "Content-Type: application/json" \
    -d '{
      "templateId": "'$template_id'",
      "originX": 0.0,
      "originY": 0.0
    }'

echo "NiFi template uploaded and instantiated."
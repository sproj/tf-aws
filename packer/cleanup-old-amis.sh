#!/bin/bash
# Keep only the latest 2 AMIs, delete older ones
DRY_RUN=${1:-false}  # Pass "true" as first argument for dry run
KEEP_COUNT=2
PROJECT_TAG="tfaws-learning"

echo "Finding AMIs tagged with Project=$PROJECT_TAG..."

# Get AMI IDs sorted by creation date (oldest first)
OLD_AMIS=$(aws ec2 describe-images \
  --owners self \
  --filters "Name=tag:Project,Values=$PROJECT_TAG" "Name=tag:AutoCleanup,Values=true" \
  --query "Images | sort_by(@, &CreationDate) | [:-$KEEP_COUNT].ImageId" \
  --output text)

if [ -n "$OLD_AMIS" ]; then
  echo "Deleting old AMIs: $OLD_AMIS"
  for AMI_ID in $OLD_AMIS; do
    # Get snapshot ID before deleting AMI
    SNAPSHOT_ID=$(aws ec2 describe-images --image-ids $AMI_ID \
      --query 'Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' --output text)
    
        if [ "$DRY_RUN" = "true" ]; then
            echo "DRY RUN: Would delete AMI: $AMI_ID (snapshot: $SNAPSHOT_ID)"
        else
            echo "Deleting AMI: $AMI_ID (snapshot: $SNAPSHOT_ID)"
            aws ec2 deregister-image --image-id $AMI_ID
            aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID
            # Add after the deletion commands:
            if [ $? -eq 0 ]; then
                echo "✅ Successfully deleted $AMI_ID"
            else
                echo "❌ Failed to delete $AMI_ID"
            fi
        fi
  done

# Summary stats
REMAINING_COUNT=$(aws ec2 describe-images --owners self \
    --filters "Name=tag:Project,Values=$PROJECT_TAG" \
    --query 'length(Images)' --output text)
echo "Cleanup complete. $REMAINING_COUNT AMIs remaining."

else
  echo "No old AMIs to clean up"
fi
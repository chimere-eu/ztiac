#cloud-config
package_update: true
package_upgrade: false

runcmd:
  - echo "This is a custom user data"
final_message: "Finished"

#!/bin/bash
set -e

dnf update -y

dnf install -y \
  httpd \
  chrony \
  audit \
  sudo

SECURITY_USER="${security_user}"

useradd -m -s /bin/bash "$SECURITY_USER"
echo "$SECURITY_USER:$(openssl rand -base64 16)" | chpasswd
echo "$SECURITY_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SECURITY_USER
chmod 440 /etc/sudoers.d/$SECURITY_USER

systemctl enable chronyd --now
chronyc makestep

systemctl enable auditd --now

cat >> /etc/audit/rules.d/audit.rules <<'EOF'
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-a always,exit -F arch=b64 -S execve -F euid=0 -k root_commands
-w /var/log/lastlog -p wa -k logins
EOF

service auditd restart

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Elastic Fleet</title>
  <style>
    body { font-family: Arial, sans-serif; display: flex; justify-content: center;
           align-items: center; height: 100vh; margin: 0; background: #f0f4f8; }
    .card { background: white; padding: 3rem; border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; }
    h1 { color: #2d3748; }
    .hostname { color: #718096; font-size: 0.9rem; margin-top: 1rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Estos servidores son elásticos</h1>
    <p class="hostname">Servidor actual: \$(hostname -f)</p>
  </div>
</body>
</html>
EOF

systemctl enable httpd --now
# Secrets Management Improvements for NixOS Configuration

## Current Issues Identified

1. **Mixed secrets management**: Using both SOPS-nix and agenix creates complexity
2. **Inconsistent key paths**: Different key file locations between system and user
3. **Missing password management**: User password is commented out
4. **Limited secret types**: Only SSH keys are currently managed
5. **No secret rotation strategy**: No mechanism for updating secrets
6. **Security gaps**: Missing fail2ban, limited SSH hardening

## Recommended Improvements

### 1. Consolidate on SOPS-nix

**Why**: SOPS-nix provides better integration with NixOS and supports multiple backends (age, GPG, AWS KMS, etc.)

**Changes**:
- Replace `users/daseeds/age.nix` with improved SOPS configuration
- Use consistent key management across system and user levels
- Leverage SOPS for all secret types

### 2. Enhanced Secret Categories

**System-level secrets** (`hosts/common/sops-improved.nix`):
- User password hashes
- SSH host keys (for consistent host identity)
- Network credentials (WiFi passwords)
- Service credentials (backup keys, API tokens)

**User-level secrets** (`users/daseeds/sops-improved.nix`):
- SSH private keys (multiple keys for different purposes)
- Git signing keys
- Application credentials (GitHub tokens, Docker config)
- Development environment variables
- GPG private keys

### 3. Security Hardening

**Enhanced user configuration** (`users/daseeds/default-improved.nix`):
- Enable password file management via SOPS
- Add security-focused groups
- Implement fail2ban for SSH protection
- Add security audit tools (lynis, rkhunter)
- Configure sudo timeouts

### 4. Key Management Best Practices

```bash
# Generate age key for SOPS
age-keygen -o ~/.config/sops/age/keys.txt

# Add public key to .sops.yaml in your secrets repository
echo "keys:
  - &daseeds age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
creation_rules:
  - path_regex: .*
    key_groups:
    - age:
      - *daseeds" > .sops.yaml

# Create/edit secrets
sops secrets.yaml
```

### 5. Migration Strategy

1. **Backup current setup**:
   ```bash
   cp -r users/daseeds users/daseeds.backup
   cp -r hosts/common hosts/common.backup
   ```

2. **Generate new age keys**:
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

3. **Update flake.nix** to remove agenix and use improved configurations:
   ```nix
   # Remove agenix input and modules
   # Update imports to use *-improved.nix files
   ```

4. **Create secrets.yaml** in your private repository with:
   ```yaml
   users:
     daseeds:
       password: ENC[AES256_GCM,data:...,tag:...,type:str]
   private_keys:
     daseeds: ENC[AES256_GCM,data:...,tag:...,type:str]
     github: ENC[AES256_GCM,data:...,tag:...,type:str]
   # ... other secrets
   ```

### 6. Operational Improvements

**Secret rotation**:
- Use SOPS updatekeys command for key rotation
- Implement automated secret rotation for service accounts
- Regular audit of secret access

**Monitoring**:
- Enable audit logging for secret access
- Monitor failed authentication attempts
- Set up alerts for suspicious activities

**Backup**:
- Encrypted backup of age keys
- Secure storage of recovery keys
- Document recovery procedures

## Implementation Steps

1. **Phase 1**: Create improved configurations (✅ Done)
2. **Phase 2**: Update flake.nix to use improved configs
3. **Phase 3**: Migrate secrets to new format
4. **Phase 4**: Test and validate
5. **Phase 5**: Remove old configurations

## Security Benefits

- **Centralized secret management**: All secrets managed through SOPS
- **Better access control**: Granular permissions per secret
- **Audit trail**: Track secret access and modifications
- **Encryption at rest**: All secrets encrypted with age/GPG
- **Key rotation**: Easy key updates without service disruption
- **Fail2ban protection**: Automatic IP blocking for failed attempts
- **Security monitoring**: Tools for system security assessment

## Fixed Issues

- ❌ Removed invalid `security.dmesg.enable` option (not available in NixOS 24.11)
- ✅ Fixed fail2ban jail configuration syntax for NixOS 24.11
- ✅ Corrected secrets input reference consistency

## Next Steps

1. **Test the improved configurations**:
   ```bash
   # Test the configuration without switching
   sudo nixos-rebuild test --flake .#eurydice
   ```

2. **If test succeeds, switch to new configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#eurydice
   ```

3. **Generate age keys for SOPS**:
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

4. **Update your secrets repository structure**
5. **Migrate existing secrets to SOPS format**
6. **Replace current files with improved versions**
7. **Remove deprecated files**

## Troubleshooting

If you encounter issues:
- Check NixOS version compatibility for specific options
- Verify all input references match your flake.nix
- Test configurations incrementally
- Keep backups of working configurations

This approach provides a more secure, maintainable, and scalable secrets management solution for your NixOS configuration.
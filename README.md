# khonager F-Droid Repository

This repository hosts a custom F-Droid-compatible app repository for `khonager` apps.

## What users do

1. Install an F-Droid-compatible client (F-Droid, Neo Store, Droid-ify).
2. Add this repository URL:
   - `https://khonager.github.io/f-droid/repo`
3. Verify the repository fingerprint shown in the Releases/Docs section of this repo.
4. Install/update apps from this repository.

## Repository layout

- `repo/`: Published APKs and generated F-Droid index files.
- `metadata/`: App metadata (`<applicationId>.yml`).
- `scripts/`: Local and CI helper scripts.
- `.github/workflows/publish.yml`: CI workflow to generate and publish repo index.

## Initial setup (one-time)

1. Enable GitHub Pages for this repository:
   - Settings -> Pages
   - Source: `GitHub Actions`
2. Create a repository signing keystore (for F-Droid index signing):
   - Run `scripts/init_keystore.sh` locally OR provide one you already use.
3. Add these GitHub secrets:
   - `FDROID_KEYSTORE_BASE64`
   - `FDROID_KEYSTORE_PASSWORD`
   - `FDROID_KEY_ALIAS`
   - `FDROID_KEY_PASSWORD`
4. Set GitHub variable:
   - `FDROID_REPO_URL` = `https://khonager.github.io/f-droid/repo`

## Add a new app

1. Add APK(s) to `metadata/apks/` (or push via CI artifact fetch).
2. Add metadata file `metadata/<applicationId>.yml`.
3. Run workflow `Publish F-Droid Repo`.

The workflow copies APKs into `repo/`, runs `fdroid update`, and publishes via GitHub Pages.

## Notes

- Keep repo signing key stable long-term; changing it forces users to re-trust the repo.
- APK signing key and F-Droid repo signing key are different concepts; both should be backed up.

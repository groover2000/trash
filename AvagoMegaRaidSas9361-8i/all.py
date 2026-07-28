#!/usr/bin/env python3

import json
import re
import subprocess
import sys


STORCLI = "/opt/MegaRAID/storcli/storcli64"


def get_storcli_json(cli_args):

    cmd = [STORCLI] + cli_args.split()

    try:

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            timeout=30
        )

        return json.loads(result.stdout)

    except subprocess.CalledProcessError as e:

        print(f"storcli execution failed: {e}", file=sys.stderr)
        sys.exit(1)

    except json.JSONDecodeError as e:

        print(f"invalid JSON from storcli: {e}", file=sys.stderr)
        sys.exit(1)

    except FileNotFoundError:

        print(f"storcli not found: {STORCLI}", file=sys.stderr)
        sys.exit(1)


def extract_int(value):

    if value is None:
        return None

    match = re.search(r"(\d+)", str(value))

    return int(match.group(1)) if match else None


def main():

    json_data = get_storcli_json("/call show J")

    result = []

    controllers = json_data.get("Controllers", [])

    for controller in controllers:

        command_status = controller.get("Command Status", {})
        response = controller.get("Response Data", {})

        controller_object = {

            "ControllerId": command_status.get("Controller"),

           
            "Model": response.get("Basics", {}).get("Model"),

            "Serial": response.get("Basics", {}).get("Serial Number"),

           
            "CacheVaultState": (
                response.get("Cachevault_Info", {})
                .get("State")
            ),

            "CacheVaultTemp": extract_int(
                response.get("Cachevault_Info", {})
                .get("Temp")
            ),

            "VD": [],
            "PD": []
        }

        #
        # Virtual Drives
        #

        for vd in response.get("VD LIST", []):

            controller_object["VD"].append({

                "ControllerId": command_status.get("Controller"),

                "Id": vd.get("DG/VD"),

                "Type": vd.get("TYPE"),

                "State": vd.get("State"),

                "Size": vd.get("Size")
            })

        #
        # Physical Drives
        #

        for pd in response.get("PD LIST", []):

            disk_id = pd.get("EID:Slt", "")

            parts = disk_id.split(":")

            enclosure_id = parts[0] if len(parts) > 0 else None
            slot = parts[1] if len(parts) > 1 else None

            controller_object["PD"].append({

                "ControllerId": command_status.get("Controller"),

                "DiskId": disk_id,

                "EnclosureId": enclosure_id,

                "Slot": slot,

                "State": pd.get("State"),

                "Size": pd.get("Size"),

                "Model": pd.get("Model")
            })

        result.append(controller_object)

    print(json.dumps(
        result,
        ensure_ascii=False,
        separators=(",", ":")
    ))


if __name__ == "__main__":
    main()

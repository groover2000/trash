#!/usr/bin/env python3

import json
import re
import subprocess
import sys


STORCLI = "/opt/MegaRAID/storcli/storcli64"

CMD = [
    STORCLI,
    "/call/eall/sall",
    "show",
    "all",
    "J"
]


def get_json():

    try:

        result = subprocess.run(
            CMD,
            capture_output=True,
            text=True,
            check=True
        )

        return json.loads(result.stdout)

    except subprocess.CalledProcessError as e:

        print(f"storcli execution failed: {e}", file=sys.stderr)
        sys.exit(1)

    except json.JSONDecodeError as e:

        print(f"invalid JSON from storcli: {e}", file=sys.stderr)
        sys.exit(1)


def extract_temp(value):

    if not value:
        return None

    match = re.search(r"(\d+)", str(value))

    return int(match.group(1)) if match else None


def main():

    raw = get_json()

    result = []

    controllers = raw.get("Controllers", [])

    for controller in controllers:

        controller_id = controller.get(
            "Command Status",
            {}
        ).get("Controller")

        response_data = controller.get(
            "Response Data",
            {}
        )

        for name, detail in response_data.items():

            if "Detailed Information" not in name:
                continue

            match = re.search(r"/e(\d+)/s(\d+)", name)

            if not match:
                continue

            eid = int(match.group(1))
            slot = int(match.group(2))

            state = None
            attr = None

            for key, value in detail.items():

                if key.endswith(" State"):
                    state = value

                elif key.endswith(" Device attributes"):
                    attr = value

            if not state or not attr:
                continue

            smart_alert = state.get(
                "S.M.A.R.T alert flagged by drive"
            )

            result.append({

                "ControllerId": controller_id,

                "Model": attr.get("Model Number"),

                "Serial": str(
                    attr.get("SN", "")
                ).strip(),

                "WWN": attr.get("WWN"),

                "Size": attr.get("Raw size"),

                "DiskID": f"{eid}:{slot}",

                "EnclosureId": eid,

                "Slot": slot,

                "MediaErrors": state.get(
                    "Media Error Count"
                ),

                "OtherErrors": state.get(
                    "Other Error Count"
                ),

                "PredictiveFailures": state.get(
                    "Predictive Failure Count"
                ),

                "SmartAlert": (
                    0 if smart_alert == "No" else 1
                ),

                "Temp": extract_temp(
                    state.get("Drive Temperature")
                )
            })

    print(json.dumps(
        result,
        indent=2,
        ensure_ascii=False
    ))


if __name__ == "__main__":
    main()

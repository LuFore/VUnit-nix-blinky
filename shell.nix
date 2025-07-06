{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell rec {
  buildInputs = [
  	pkgs.nvc
		pkgs.python310 
    pkgs.python310Packages.virtualenv
	];

  shellHook = ''
    # Create a virtualenv if it doesn't exist
    if [ ! -d "venv" ]; then
      echo "Creating virutal Enviroment"
			python3 -m venv venv
    fi

		echo "Activating virtual enviroment"
    source venv/bin/activate

    # If first time, use pip to install requirements
    echo "Checking/Installing pip packages"
    pip install --upgrade pip
    pip install -r requirements.txt
  '';
}

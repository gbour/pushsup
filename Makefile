
APP=pushsup_app

build:
	./rebar prepare-deps

debug:
	erl -pa ebin/ `find deps -name ebin` -s $(APP)

release:
	./rebar generate

clean:
	./rebar clean

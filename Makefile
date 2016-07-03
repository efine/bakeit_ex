.PHONY: all deps clean

MIX=mix

all: deps
	@$(MIX) do clean, compile, escript.build

deps:
	@$(MIX) deps.get

clean:
	@$(MIX) clean
	rm -rf _build deps

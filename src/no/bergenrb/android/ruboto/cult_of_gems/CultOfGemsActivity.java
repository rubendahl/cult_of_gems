package no.bergenrb.android.ruboto.cult_of_gems;

import android.os.Bundle;

public class CultOfGemsActivity extends org.ruboto.EntryPointActivity {
	public void onCreate(Bundle bundle) {
		getScriptInfo().setRubyClassName(getClass().getSimpleName());
	    super.onCreate(bundle);
	}
}

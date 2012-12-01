package com.unstoppable.wmp.timer;

import com.unstoppable.wmp.timer.Stopwatch;
import com.unstoppable.wmp.timer.Timer;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;

public class WMPTimer extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wmptimer);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_wmptimer, menu);
        return true;
    }
    
    public void runSwatch(View view){
    	Intent intent = new Intent(this, Stopwatch.class);
    	startActivity(intent);
    }
    
    public void runTimer(View view){
    	Intent intent = new Intent(this, Timer.class);
    	startActivity(intent);
    }
}

<?php

use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return ['Laravel' => app()->version()];
});

// create a post route to send an email and get the body conten of the email
Route::post('/send-email', function () {
    $data = Request::all();

    // Validate required fields
    if (!isset($data['to']) || !isset($data['url'])) {
        return response()->json(['error' => 'Missing required fields'], 400);
    }

    try {
        // Send raw email text instead of using template
        Mail::raw("Reset your password by clicking this link: {$data['url']}", function ($message) use ($data) {
            $message->to($data['to'])
                   ->subject('Reset Password');
        });

        return response()->json(['message' => 'Email sent successfully']);
    } catch (\Exception $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});


require __DIR__ . '/auth.php';

const { exec } = require('child_process');
const bruteForce = require('bruteforce');

function bruteKeychain(password) {
    return new Promise(resolve => {
        exec(`security unlock-keychain -p "${password}" ~/Library/Keychains/test.keychain`, (err, stdout, stderr) => {
            resolve(!stderr);
        });
    })
}

function brute(length, startTime) {

    (async() => {
        const check = bruteForce({
            len: length,
            chars: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@'.split('')
        })
        
        for (let i = 0; i < check.length; i++) {
            let result = await bruteKeychain(check[i]);
            if (result) {
                console.log('Password is: ', check[i]);
                console.log('Time taken: ', Date.now() - startTime);
                throw new Error('Found password');
            }
        }
    })();
}

    let startTime = Date.now();
    for (let len = 0; len < 25; len++) {
        brute(len, startTime);
        console.log(len)
    }


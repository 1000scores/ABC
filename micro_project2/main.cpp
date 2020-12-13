#include <iostream>
#include <pthread.h>
#include <vector>
#include <unistd.h>
#include <ctime>

using namespace std;

typedef long long ll;

const ll PROGRAM_RUNNING_TIME = 10; // 10 seconds;

vector<pthread_mutex_t> talkers;
int n;
ll start_time;
pthread_mutex_t print_mutex;

void call(int id1, int id2) {
    if(id1 == id2) return;
    if(!pthread_mutex_trylock(&talkers[id1])) {
        if(!pthread_mutex_trylock(&talkers[id2])) {
            pthread_mutex_lock(&print_mutex);
            cout << "Talker #" << id1 << " talking to Talker #" << id2 << endl;
            pthread_mutex_unlock(&print_mutex);
            sleep(1);
            pthread_mutex_unlock(&talkers[id2]);
        }
        pthread_mutex_unlock(&talkers[id1]);
    }
}

struct struct_id {
    int id;
};

void *start_calling(void *input) {
    int id = ((struct struct_id*)input)->id;
    while(time(nullptr) - start_time < PROGRAM_RUNNING_TIME) {
        call(id, rand() % n);
    }
}

int main() {
    cout << "Write number of talkers please (int): " << endl;
    cin >> n;
    if(n < 2) {
        cout << "Number of talkers should be more than 1!" << endl;
        return -1;
    }
    talkers.resize(n);
    start_time = time(nullptr);
    pthread_t callers[n];
    for(int i = 0; i < n; i++) {
        pthread_mutex_init(&talkers[i], NULL);
    }
    for(int i = 0; i < n; i++) {
        struct struct_id *cur_caller = (struct struct_id *)malloc(sizeof(struct struct_id));
        cur_caller->id = i;
        pthread_create(&callers[i], NULL, start_calling, (void *)cur_caller);
    }

    for(int i = 0; i < n; i++) {
        pthread_join(callers[i], NULL);
    }

    return 0;
}

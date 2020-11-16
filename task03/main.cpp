#include <mutex>
#include <condition_variable>
#include <iostream>
#include <pthread.h>
#include <semaphore.h>

using namespace std;

const int PINS_NUM = 10;
const int GOOD_CURVE = 15;
const int BUFFER12_SIZE = 10;
const int BUFFER23_SIZE = 10;


// Исходные булавки для первого рабочего [0, PINS_NUM)
int *pins; // значения кривизны булавки из полуинтервала [0, GOOD_CURVE*2)

pthread_mutex_t mut12;
int *buffer12; // очередь от первого ко второму с не кривыми булавками
int index_buffer12 = 0; // Индекс буффера12 куда складываем
int out_buffer12 = 0; // Индекс буффера12 для обработки
sem_t empty12;
sem_t full12;

pthread_mutex_t mut23;
int *buffer23;
int index_buffer23 = 0; // Индекс буффера23 куда складываем
int out_buffer23 = 0; // Индекс буффера23 для обработки
sem_t empty23;
sem_t full23;

int good_pins = PINS_NUM;

void *worker1(void *args) {
    // cout << "In worker1" << endl;
    for(int i = 0; i < PINS_NUM; i++) {
        if(pins[i] >= GOOD_CURVE) {
            sem_wait(&empty12);
            pthread_mutex_lock(&mut12);
            cout << "(worker1) Pin with good curve ( >= GOOD_CURVE): " << pins[i] << endl;
            buffer12[index_buffer12] = pins[i];
            index_buffer12 = (index_buffer12 + 1) % BUFFER12_SIZE;
            pthread_mutex_unlock(&mut12);
            sem_post(&full12);
        } else {
            good_pins--;
            cout << "(worker1) Pin with bad curve (<GOOD_CURVE) to garbage: " << pins[i] << endl;
            // Выбрасывает кривую булавку
        }
    }

}

void *worker2(void *args) {
    // cout << "In worker2" << endl;
    for(int i = 0; i < good_pins; i++) {
        sem_wait(&full12);
        pthread_mutex_lock(&mut12);
        pthread_mutex_lock(&mut23);

        buffer23[index_buffer23] = buffer12[out_buffer12] + 100;
        cout << "(worker2) Made " << buffer23[index_buffer23] << " pin ( +100 )" << endl;
        index_buffer23 = (index_buffer23 + 1) % BUFFER23_SIZE;
        out_buffer12 = (out_buffer12 + 1) % BUFFER12_SIZE;
        pthread_mutex_unlock(&mut23);
        pthread_mutex_unlock(&mut12);
        sem_post(&full23);
    }
}

void *worker3(void *args) {
    // cout << "In worker3" << endl;
    for(int i = 0; i < good_pins; i++) {
        sem_wait(&full23);
        pthread_mutex_lock(&mut23);
        if(buffer23[out_buffer23] >= 120) {
            cout << "(worker3) One of final pins (>=120): " <<  buffer23[out_buffer23] << endl;
        }
        out_buffer23 = (out_buffer23 + 1) % BUFFER23_SIZE;
        pthread_mutex_unlock(&mut23);
    }
}


int main() {
    srand((unsigned int)time(NULL));
    sem_init(&full12,0,0);
    sem_init(&empty12,0,PINS_NUM);
    sem_init(&full23,0,0);
    sem_init(&empty23,0,PINS_NUM);
    pthread_mutex_init(&mut12, NULL);
    pthread_mutex_init(&mut23, NULL);


    pins = new int[PINS_NUM];
    buffer12 = new int[BUFFER12_SIZE];
    buffer23 = new int[BUFFER23_SIZE];
    cout << "Pins:" << endl;
    for(int i = 0; i < PINS_NUM; i++) {
        pins[i] = rand() % (GOOD_CURVE * 2);
        cout << pins[i] << " ";
    }
    cout << endl;

    pthread_t workers[3];
    pthread_create(&workers[0], NULL, worker1, NULL);
    pthread_create(&workers[1], NULL, worker2, NULL);
    pthread_create(&workers[2], NULL, worker3, NULL);
    pthread_join(workers[0], NULL);
    pthread_join(workers[1], NULL);
    pthread_join(workers[2], NULL);
    return 0;
}
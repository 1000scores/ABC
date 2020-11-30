#include <mutex>
#include <condition_variable>
#include <iostream>
#include <mutex>
#include <omp.h>

using namespace std;

const int PINS_NUM = 10;
const int GOOD_CURVE = 15;
const int BUFFER12_SIZE = 10;
const int BUFFER23_SIZE = 10;


struct Buffer {
    int size;
    int* ar;
    int index_put = 0;
    int index_take = 0;
    Buffer(int _size) {
        this->size = _size;
        ar = new int[this->size];
    }

    void put(int elem) {
        ar[index_put] = elem;
        index_put = (index_put + 1) % this->size;
    }

    int take() {
        int temp_answer = ar[index_take];
        index_take = (index_take + 1) % this->size;
        return temp_answer;
    }
};



int worker1_one(int pin, Buffer buffer) {
    if (pin >= GOOD_CURVE) {
#pragma omp critical
        cout << "(worker1) Pin with good curve ( >= GOOD_CURVE): " << pin << endl;
    }
    else {
        pin = -1;
#pragma omp critical
        cout << "(worker1) Pin with bad curve (<GOOD_CURVE) to garbage(-1): " << pin << endl;
    }

    buffer.put(pin);
}

void worker2_one(int pin, Buffer buffer) {
    if(pin == -1) {
        buffer.put(-1);
        return;
    }
    pin += 100;
#pragma omp critical
    cout << "(worker2) Made " << pin << " pin ( +100 )" << endl;

    buffer.put(pin);
}

void worker3_one(int pin) {
    if(pin == -1) return;
    if (pin >= 120) {
#pragma omp critical
        cout << "(worker3) One of final pins (>=120): " << pin << endl;
    }
}


int main() {
    srand((unsigned int)time(NULL));
    // Исходные булавки для первого рабочего [0, PINS_NUM)
    int* pins; // значения кривизны булавки из полуинтервала [0, GOOD_CURVE*2)

    pins = new int[PINS_NUM];
    cout << "Pins:" << endl;
    for (int i = 0; i < PINS_NUM; i++) {
        pins[i] = rand() % (GOOD_CURVE * 2);
        cout << pins[i] << " ";
    }
    cout << endl;
    int pin_x = 0;
    int pin_y = 0;
    int pin_z = 0;
    int index = 0;
#pragma omp parallel num_threads(PINS_NUM)
    {
        Buffer buffer12(BUFFER12_SIZE);
        Buffer buffer23(BUFFER23_SIZE);
#pragma omp task depend(in: pin_x) depend(out: pin_y)
        worker1_one(pins[index++], buffer12);

#pragma omp task depend(in: pin_y) depend(out: pin_z)
        worker2_one(buffer12.take(), buffer23);

#pragma omp task depend(in: pin_z) depend(out: pin_z)
        worker3_one(buffer23.take());
    }

}
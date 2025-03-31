/****************************************************************************
** Meta object code from reading C++ file 'spectrogramgenerator.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.16)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "include/spectrogramgenerator.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'spectrogramgenerator.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.16. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_SpectrogramGenerator_t {
    QByteArrayData data[23];
    char stringdata0[280];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_SpectrogramGenerator_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_SpectrogramGenerator_t qt_meta_stringdata_SpectrogramGenerator = {
    {
QT_MOC_LITERAL(0, 0, 20), // "SpectrogramGenerator"
QT_MOC_LITERAL(1, 21, 11), // "QML.Element"
QT_MOC_LITERAL(2, 33, 4), // "auto"
QT_MOC_LITERAL(3, 38, 20), // "spectrogramGenerated"
QT_MOC_LITERAL(4, 59, 0), // ""
QT_MOC_LITERAL(5, 60, 7), // "success"
QT_MOC_LITERAL(6, 68, 10), // "outputPath"
QT_MOC_LITERAL(7, 79, 12), // "errorMessage"
QT_MOC_LITERAL(8, 92, 19), // "generateSpectrogram"
QT_MOC_LITERAL(9, 112, 7), // "fftSize"
QT_MOC_LITERAL(10, 120, 7), // "overlap"
QT_MOC_LITERAL(11, 128, 7), // "minFreq"
QT_MOC_LITERAL(12, 136, 7), // "maxFreq"
QT_MOC_LITERAL(13, 144, 8), // "duration"
QT_MOC_LITERAL(14, 153, 10), // "sampleRate"
QT_MOC_LITERAL(15, 164, 14), // "dynamicRangeDB"
QT_MOC_LITERAL(16, 179, 15), // "gammaCorrection"
QT_MOC_LITERAL(17, 195, 15), // "enableDithering"
QT_MOC_LITERAL(18, 211, 14), // "contrastFactor"
QT_MOC_LITERAL(19, 226, 15), // "enableHighBoost"
QT_MOC_LITERAL(20, 242, 14), // "highBoostAlpha"
QT_MOC_LITERAL(21, 257, 9), // "inputFile"
QT_MOC_LITERAL(22, 267, 12) // "outputFolder"

    },
    "SpectrogramGenerator\0QML.Element\0auto\0"
    "spectrogramGenerated\0\0success\0outputPath\0"
    "errorMessage\0generateSpectrogram\0"
    "fftSize\0overlap\0minFreq\0maxFreq\0"
    "duration\0sampleRate\0dynamicRangeDB\0"
    "gammaCorrection\0enableDithering\0"
    "contrastFactor\0enableHighBoost\0"
    "highBoostAlpha\0inputFile\0outputFolder"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_SpectrogramGenerator[] = {

 // content:
       8,       // revision
       0,       // classname
       1,   14, // classinfo
       3,   16, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // classinfo: key, value
       1,    2,

 // signals: name, argc, parameters, tag, flags
       3,    3,   31,    4, 0x06 /* Public */,
       3,    2,   38,    4, 0x26 /* Public | MethodCloned */,

 // methods: name, argc, parameters, tag, flags
       8,   14,   43,    4, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void, QMetaType::Bool, QMetaType::QString, QMetaType::QString,    5,    6,    7,
    QMetaType::Void, QMetaType::Bool, QMetaType::QString,    5,    6,

 // methods: parameters
    QMetaType::Void, QMetaType::Int, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Int, QMetaType::Double, QMetaType::Double, QMetaType::Bool, QMetaType::Double, QMetaType::Bool, QMetaType::Double, QMetaType::QString, QMetaType::QString,    9,   10,   11,   12,   13,   14,   15,   16,   17,   18,   19,   20,   21,   22,

       0        // eod
};

void SpectrogramGenerator::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SpectrogramGenerator *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->spectrogramGenerated((*reinterpret_cast< bool(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3]))); break;
        case 1: _t->spectrogramGenerated((*reinterpret_cast< bool(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 2: _t->generateSpectrogram((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< double(*)>(_a[3])),(*reinterpret_cast< double(*)>(_a[4])),(*reinterpret_cast< double(*)>(_a[5])),(*reinterpret_cast< int(*)>(_a[6])),(*reinterpret_cast< double(*)>(_a[7])),(*reinterpret_cast< double(*)>(_a[8])),(*reinterpret_cast< bool(*)>(_a[9])),(*reinterpret_cast< double(*)>(_a[10])),(*reinterpret_cast< bool(*)>(_a[11])),(*reinterpret_cast< double(*)>(_a[12])),(*reinterpret_cast< const QString(*)>(_a[13])),(*reinterpret_cast< const QString(*)>(_a[14]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (SpectrogramGenerator::*)(bool , const QString & , const QString & );
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&SpectrogramGenerator::spectrogramGenerated)) {
                *result = 0;
                return;
            }
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject SpectrogramGenerator::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_SpectrogramGenerator.data,
    qt_meta_data_SpectrogramGenerator,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *SpectrogramGenerator::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SpectrogramGenerator::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_SpectrogramGenerator.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int SpectrogramGenerator::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 3)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 3)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 3;
    }
    return _id;
}

// SIGNAL 0
void SpectrogramGenerator::spectrogramGenerated(bool _t1, const QString & _t2, const QString & _t3)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t2))), const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t3))) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE

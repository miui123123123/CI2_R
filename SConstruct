# -*- coding: utf-8 -*-

import fnmatch
import os

def FindFiles(directory, mask):
    files = []
    for root, dirnames, filenames in os.walk(directory):
        for filename in fnmatch.filter(filenames, mask):
            if not filename.startswith('_test_'):
                files.append(os.path.join(root, filename))
    return files

TARGET_FILE_NAME = 'chickeninvaders'
TARGET_FILE_EXT = ''

AddOption('--use_sfml',
          dest='use_sfml',
          action='store_true',
          help='use sfml instead sdl')

USE_SFML = GetOption('use_sfml')

AddOption('--c++11',
          dest='c++11',
          action='store_true',
          help='use c++11')

USE_CPP11 = GetOption('c++11')

env = Environment(ENV=os.environ)
if 'TERM' in os.environ:
    env['ENV']['TERM'] = os.environ['TERM']

# Use clang++ instead of g++
env['CXX'] = '/data/data/com.termux/files/usr/bin/clang++'
env['CC'] = '/data/data/com.termux/files/usr/bin/clang'

# Termux SDL2 include path
SDL_INCLUDE = '/data/data/com.termux/files/usr/include/SDL2'
SDL_LIB = '/data/data/com.termux/files/usr/lib'

env.Append(CPPPATH=[SDL_INCLUDE])

libs = ['tinyxml', 'boost_chrono', 'boost_thread']

if USE_SFML:
    libs += ['sfml-graphics', 'sfml-window', 'sfml-system', 'sfml-audio']
else:
    env.Append(LIBPATH=[SDL_LIB])
    libs += ['SDL2', 'SDL2_mixer', 'openal', 'sndfile']

AddOption('--mode',
          dest='mode',
          type='string',
          nargs=1,
          help='build mode',
          default='release')

modecfg = {
            'release': {
                'flags': ['-O3'],
                'defines': ['NDEBUG']
            },
            'debug': {
                'flags': ['-g3', '-O0'],
                'defines': ['DEBUG']
            }
        }.get(GetOption('mode'))

if not modecfg:
    raise Exception('Unknown build mode: "%s"' % GetOption('mode'))

env.Append(CCFLAGS=['-Wextra', '-I.', '-DUSE_BOOST_CHRONO',
                    '-DBOOST_SP_DISABLE_THREADS', '-DTIXML_USE_STL',
                    modecfg['flags']])
if USE_CPP11:
    env.Append(CCFLAGS=['--std=c++11', '-DCPP11'])
if USE_SFML:
    env.Append(CCFLAGS=['-DUSE_SFML'])
env.Append(CPPDEFINES=[modecfg['defines']])
env.Program(target=TARGET_FILE_NAME + TARGET_FILE_EXT,
            source=FindFiles('.', '*.cpp'),
            LIBS=libs, CPPPath='.')
